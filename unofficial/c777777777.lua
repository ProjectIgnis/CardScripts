--Rule of the day: Light of Intervention
local s,id=GetID()
function s.initial_effect(c)
	aux.GlobalCheck(s,function()
		--Monsters can be Normal Summoned in DEF Mode
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_LIGHT_OF_INTERVENTION)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		Duel.RegisterEffect(e1,0)
	end)
end