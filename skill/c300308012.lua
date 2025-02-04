--Shouldering a Destiny
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,true,s.flipcon,s.flipop)
end
s.listed_names={83965310} --"Destiny HERO - Plasma"
function s.flipcon(e)
	local tp=e:GetHandlerPlayer()
	return aux.CanActivateSkill(tp) and not Duel.HasFlagEffect(tp,id) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
	Duel.Hint(HINT_SKILL_REMOVE,tp,c:GetOriginalCode())
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--While you control "Destiny HERO - Plasma", you cannot draw during the Draw Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_DRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(aux.AND(s.plasmacon,s.drawcon))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_DRAW_COUNT)
	e3:SetCondition(s.plasmacon)
	e3:SetValue(0)
	c:RegisterEffect(e3)
	--Each "Destiny HERO - Plasma" you control gains 100 ATK for each monster in the GYs, cannot be destroyed by your opponent's card effects, also can make a second attack during each Battle Phase
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.plasmacon)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsCode,83965310))
	e4:SetValue(function(e,c) return Duel.GetMatchingGroupCount(Card.IsMonster,0,LOCATION_GRAVE,LOCATION_GRAVE,nil)*100 end)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetTargetRange(LOCATION_ONFIELD,0)
	e5:SetValue(aux.indoval)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_EXTRA_ATTACK)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	--Activate this Skill as a Continuous Spell
	Duel.Activate(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsCode(83965310) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.plasmacon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,83965310),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.drawcon()
	return Duel.IsPhase(PHASE_DRAW)
end
