// Entry point for the build script in your package.json
import * as Turbo from '@hotwired/turbo'
import "./controllers"
import TurboPower from 'turbo_power'

TurboPower.initialize(Turbo.StreamActions)
