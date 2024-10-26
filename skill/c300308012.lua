--Shouldering a Destiny
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,true,s.flipcon,s.flipop)
end
s.listed_names={83965310}
function s.thfilter(c)
	return c:IsCode(83965310) and c:IsAbleToHand()
end
function s.flipcon(e)
	local tp=e:GetHandlerPlayer()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0 and ft>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SKILL_FLIP,tp,id|1<<32)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	Duel.Hint(HINT_SKILL_REMOVE,tp,c:GetOriginalCode())
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
	--You cannot draw cards during the Draw Phase while you control "Destiny HERO - Plasma"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_DRAW)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(aux.AND(s.plasmacon,s.drawcon))
	c:RegisterEffect(e1)
	--"Destiny HERO - Plasma" you control gains 100 ATK for each monster in both GYs
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.plasmacon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,83965310))
	e2:SetValue(function(e,c) return Duel.GetMatchingGroupCount(Card.IsMonster,0,LOCATION_GRAVE,LOCATION_GRAVE,nil)*100 end)
	c:RegisterEffect(e2)
	--"Destiny HERO - Plasma" you control cannot be destroyed by opponent's card effects
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	--"Destiny HERO - Plasma" you control can make a second attack each Battle Phase
	local e4=e2:Clone()
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
function s.plasmacon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,83965310),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.drawcon(e)
	return Duel.GetCurrentPhase()==PHASE_DRAW
end
