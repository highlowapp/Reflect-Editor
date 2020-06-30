let generateId = () => {
    let s4 = () => {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    }
    //return id of format 'aaaaaaaa'-'aaaa'-'aaaa'-'aaaa'-'aaaaaaaaaaaa'
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
}

const templates = {
    'h1': h1Block
}

class Block {
    constructor(attributes) {
        this.id = generateId()
        this.editable = attributes['editable']
        this.attributes = attributes
        this.createElement(attributes)
    }

    createElement(attributes) {
        this.el = document.createElement('div')
    }

    getElement() {
        return this.el
    }

    addTo(editor) {
        const block = this.prepareBlock()
        editor.appendChild(block)
    }

    addAfter(editor, block) {
        const newBlock = this.prepareBlock()
        editor.insertBefore(newBlock, block.nextSibling)
    }

    prepareBlock() {
        const block = document.createElement('div')
        block.id = this.id
        block.classList.add('block')
        const dragger = document.createElement('div')
        dragger.classList.add('material-icons')
        dragger.classList.add('blockHandle')
        if (this.editable) {
            dragger.innerHTML = 'drag_handle'
        } else {
            dragger.innerHTML = 'lock'
            dragger.classList.add('locked')
        }
        block.appendChild(dragger)
        block.appendChild(this.el)
        return block
    }

    handOff(block) {
        block.id = this.id
        block.attributes = this.attributes
        block.editable = this.editable
    }

    exportJson() {
        return {}
    }
}

class H1Block extends Block {
    constructor(content) {
        super(content)
        this.type = 'h1'
    }

    createElement(attributes) {
        this.el = document.createElement('h1')
        this.el.contentEditable = this.editable
        if ('content' in attributes) {
            this.el.innerText = attributes['content']
        }
    }

    exportJson() {
        return {
            type: this.type,
            content: this.el.innerHTML,
            editable: this.editable
        }
    }
}

class H2Block extends Block {
    constructor(content) {
        super(content)
        this.type = 'h2'
    }

    createElement(attributes) {
        this.el = document.createElement('h2')
        this.el.contentEditable = this.editable
        if ('content' in attributes) {
            this.el.innerText = attributes['content']
        }
    }

    exportJson() {
        return {
            type: this.type,
            content: this.el.innerHTML,
            editable: this.editable
        }
    }
}

class PBlock extends Block {
    constructor(content) {
        super(content)
        this.type = 'p'
    }

    createElement(attributes) {
        this.el = document.createElement('p')
        this.el.contentEditable = this.editable
        if ('content' in attributes) {
            this.el.innerHTML = attributes['content']
        }
    }

    exportJson() {
        return {
            type: this.type,
            content: this.el.innerHTML,
            editable: this.editable
        }
    }
}