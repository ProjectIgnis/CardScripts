--Japanese name
--Great Mammoth of the Netherworld
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Special Summoned and you control "Call of the Haunted" or a Zombie monster, except "Great Mammoth of the Netherworld": You can target 1 card on the field; destroy it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--A Zombie Xyz Monster that has this card as material gains this effect: ● Gains 1000 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) local c=e:GetHandler() return c:IsRace(RACE_ZOMBIE) and c:IsXyzMonster() end)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_CALL_OF_THE_HAUNTED,id}
function s.desconfilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_CALL_OF_THE_HAUNTED) or (c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_ZOMBIE) and not c:IsCode(id)))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and Duel.IsExistingMatchingCard(s.desconfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end