--ワルキューレ・ブリュンヒルデ (Anime)
--Valkyrie Brunhilde (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Unaffected by your opponent's Spell effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,te) return te:IsSpellEffect() and te:GetOwnerPlayer()~=e:GetHandlerPlayer() end)
	c:RegisterEffect(e1)
	--Gains 300 ATK for each Dragon and Warrior monster on the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,c) return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_DRAGON|RACE_WARRIOR),0,LOCATION_MZONE,LOCATION_MZONE,nil)*300 end)
	c:RegisterEffect(e2)
	--If this card would be destroyed by battle with a monster, you can have it lose exactly 1000 DEF instead.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.desreptg)
	c:RegisterEffect(e3)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE) and c:IsFaceup() and c:IsDefenseAbove(1000) end
	if Duel.SelectYesNo(tp,aux.Stringid(40945356,0)) then
		c:UpdateDefense(-1000,RESET_EVENT|RESETS_STANDARD_DISABLE)
		return true
	else return false end
end
