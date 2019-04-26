--コロッサス・オブ・エンドレス・ナイト
--Colossus of Everlasting Night
--Scripted by Eerie Code
function c120401049.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_TRAP),2,2)
	--todeck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c120401049.tdtg)
	e1:SetOperation(c120401049.tdop)
	c:RegisterEffect(e1)
	--cannot be target/destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c120401049.tgtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e3)
	--trap monster support
	if not Card.IsTrapMonster then
		function Card.IsTrapMonster(c)
			return c:IsCode(3129635,4904633,8522996,13955608,20960340,21843307,23626223,26905245,27062594,28649820,42237854,43959432,49514333,50277973,54241725,54297661,60433216,70406920,79852326,87772572,90440725,92092092,92099232,97232518) or c.trap_monster
		end
	end
end
function c120401049.tdfilter(c)
	return c:GetType()==TYPE_CONTINUOUS+TYPE_TRAP and c:IsAbleToDeck()
end
function c120401049.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c120401049.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c120401049.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c120401049.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function c120401049.thfilter(c,tp)
	return c:IsTrapMonster() and c:GetActivateEffect():IsActivatable(tp,true)
end
function c120401049.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
		local g=Duel.GetMatchingGroup(c120401049.thfilter,tp,LOCATION_HAND,0,1,nil,tp)
		if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(120401049,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local te=sc:GetActivateEffect()
			local tep=sc:GetControler()
			local cost=te:GetCost()
			local tg=te:GetTarget()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			if tg then tg(te,tep,eg,ep,ev,re,r,rp,1) end
		end
	end
end
function c120401049.tgtg(e,c)
	return c:IsType(TYPE_TRAP) and c:IsLocation(LOCATION_MZONE) 
		and e:GetHandler():GetLinkedGroup():IsContains(c)
end
