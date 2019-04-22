--心眼の祭殿
--Altar of the Mind's Eye
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(id)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,1)
	c:RegisterEffect(e3)
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local eff={Duel.GetPlayerEffect(ep,EFFECT_REVERSE_DAMAGE)}
	if eff then
		for _,te in ipairs(eff) do
			local val=te:GetValue()
			if type(val)=='function' then
				if val(e,re,r,rp,rc) then return end
			else return end
		end
	end
	Duel.ChangeBattleDamage(ep,1000)
end
