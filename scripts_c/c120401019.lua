--ヴォルカニック・ガトリング
--Volcanic Gatling
--Scripted by Eerie Code
function c120401019.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PYRO),2)
	--cannot be battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c120401019.atlimit)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(120401019,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,120401019)
	e2:SetTarget(c120401019.destg)
	e2:SetOperation(c120401019.desop)
	c:RegisterEffect(e2)
end
function c120401019.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x32) and c~=e:GetHandler()
end
function c120401019.tdfilter(c,e)
	return c:IsFaceup() and c:IsRace(RACE_PYRO) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end
function c120401019.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local lg=e:GetHandler():GetLinkedGroup()
	local tg=lg:Filter(c120401019.tdfilter,nil,e)
	if chk==0 then return tg:GetCount()>0
		and Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_ONFIELD,tg:GetCount(),tg) end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,tg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,tg:GetCount(),1-tp,LOCATION_ONFIELD)
end
function c120401019.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()==0 then return end
	if Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)~=0 then
		local oc=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA):GetCount()
		if oc==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,oc,oc,nil)
		if g:GetCount()>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
