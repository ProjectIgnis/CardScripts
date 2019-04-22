--ルーレット・ドラゴン
--Roulette Dragon
--Scripted by Eerie Code
function c120401007.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c120401007.matfilter,2)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(120401007,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c120401007.destg1)
	e1:SetOperation(c120401007.desop1)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(120401007,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c120401007.descost)
	e2:SetTarget(c120401007.destg2)
	e2:SetOperation(c120401007.desop2)
	c:RegisterEffect(e2)
end
c120401007.toss_coin=true
function c120401007.matfilter(c,lc,sumtype,tp)
	return c:IsType(TYPE_EFFECT,lc,sumtype,tp) and c:IsRace(RACE_MACHINE,lc,sumtype,tp)
end
function c120401007.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return lg and lg:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,lg:GetCount())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,lg,lg:GetCount(),0,0)
end
function c120401007.desop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local lg=e:GetHandler():GetLinkedGroup()
	if not lg then return end
	for tc in aux.Next(lg) do
		Duel.HintSelection(Group.FromCards(tc))
		local opt=Duel.SelectOption(tp,60,61)
		local coin=Duel.TossCoin(tp,1)
		if opt==coin then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
function c120401007.cfilter(c,g)
	return g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c120401007.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return Duel.CheckReleaseGroup(tp,c120401007.cfilter,1,nil,lg) end
	local g=Duel.SelectReleaseGroup(tp,c120401007.cfilter,1,1,nil,lg)
	Duel.Release(g,REASON_COST)
end
function c120401007.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c120401007.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
