--魔救の救砕
--Adamancipator Relief
--Logical Nonsense
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Tribute any number of "Adamacia" monsters, destroy that many cards +1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
	--Part of "Adamacia" archetype
s.listed_series={0x140}
	--Check for "Adamacia" monster
function s.cfilter(c)
	return c:IsSetCard(0x140) and c:IsType(TYPE_MONSTER)
end
function s.spcheck(sg,tp,exg,oc)
	local ex=sg:Clone()
	ex:AddCard(oc)
	return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,#sg+1,ex)
end
	--Tribute cost
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,s.spcheck,nil,e:GetHandler()) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,99,false,s.spcheck,nil,e:GetHandler())
	local ct=Duel.Release(g,REASON_COST)
	e:SetLabel(ct)
end
	--Activation legality
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	local ct=e:GetLabel()+1
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
	--Destroy cards equal to number of tributed monsters +1
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
