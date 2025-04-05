--ヴェルズ・ウロボロス
--Evilswarm Ouroboros
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,4,3)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.Detach(1,1,nil))
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local op=e:GetLabel()
		if op==2 or not chkc:IsControler(1-tp) then return false end
		if op==1 then
			return chkc:IsOnField() and chkc:IsAbleToHand()
		elseif op==3 then
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove()
		end
	end
	local c=e:GetHandler()
	--Return 1 card your opponent controls to the hand
	local b1=not c:HasFlagEffect(id)
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
	--Send 1 random card from your opponent's hand to the GY
	local b2=not c:HasFlagEffect(id+1)
		and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
	--Banish 1 card from your opponent's GY
	local b3=not c:HasFlagEffect(id+2)
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	c:RegisterFlagEffect(id+op-1,RESET_EVENT|RESETS_STANDARD,0,1)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOGRAVE)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
	elseif op==3 then
		e:SetCategory(CATEGORY_REMOVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Return 1 card your opponent controls to the hand
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	elseif op==2 then
		--Send 1 random card from your opponent's hand to the GY
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if #g>0 then
			local sg=g:RandomSelect(1-tp,1)
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	elseif op==3 then
		--Banish 1 card from your opponent's GY
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end