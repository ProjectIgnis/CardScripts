--Ｎｏ．１０１ Ｓ・Ｈ・Ａｒｋ Ｋｎｉｇｈｔ－ソウル・アサイラム
--Number 101: Silent Honor ARK - Soul Asylum
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	--You can detach 1 material from this card, then activate 1 of these effects;
	--● Choose 1 Level 4 monster in your GY, except the detached material, and add 1 Level 4 monster with the same Type and Attribute, but a different name, from your Deck to your hand
	--● Target 1 monster your opponent controls; attach it to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--If this card would be destroyed, you can detach 1 material from this card instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
		return Duel.SelectEffectYesNo(tp,c,96) and c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)>0
	end)
	c:RegisterEffect(e2)
end
s.xyz_number=101
function s.gyfilter(c,tp)
	return c:IsLevel(4) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetRace(),c:GetAttribute(),c:GetCode())
end
function s.thfilter(c,race,attr,code)
	return c:IsLevel(4) and c:IsRace(race) and c:IsAttribute(attr) and not c:IsCode(code)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local cd=Chain.GetCurrentLink()>0 and e:GetChainData() or nil
	if chkc then return cd and cd.choice==2 and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) end
	--● Choose 1 Level 4 monster in your GY, except the detached material, and add 1 Level 4 monster with the same Type and Attribute, but a different name, from your Deck to your hand
	local exc=cd and cd.cost_detached_materials:GetFirst() or nil
	local option_1=Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,exc,tp)
	--● Target 1 monster your opponent controls; attach it to this card
	local option_2=c:IsXyzMonster() and Duel.IsExistingTarget(Card.IsCanBeXyzMaterial,tp,0,LOCATION_MZONE,1,nil,c,tp,REASON_EFFECT)
	if chk==0 then return option_1 or option_2 end
	cd.choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,1)},
		{option_2,aux.Stringid(id,2)})
	if cd.choice==1 then
		--● Choose 1 Level 4 monster in your GY, except the detached material, and add 1 Level 4 monster with the same Type and Attribute, but a different name, from your Deck to your hand
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		exc:CreateEffectRelation(e)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif cd.choice==2 then
		--● Target 1 monster your opponent controls; attach it to this card
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
		Duel.SelectTarget(tp,Card.IsCanBeXyzMaterial,tp,0,LOCATION_MZONE,1,1,nil,c,tp,REASON_EFFECT)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetChainData()
	local choice=cd.choice
	if choice==1 then
		--● Choose 1 Level 4 monster in your GY, except the detached material, and add 1 Level 4 monster with the same Type and Attribute, but a different name, from your Deck to your hand
		local detached_mat=cd.cost_detached_materials:GetFirst()
		local exc=detached_mat:IsRelateToEffect(e) and detached_mat or nil
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local gyc=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,exc,tp):GetFirst()
		if not gyc then return end
		Duel.HintSelection(gyc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,gyc:GetRace(),gyc:GetAttribute(),gyc:GetCode())
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif choice==2 then
		--● Target 1 monster your opponent controls; attach it to this card
		local c=e:GetHandler()
		local tc=Duel.GetFirstTarget()
		if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) then
			Duel.Overlay(c,tc)
		end
	end
end