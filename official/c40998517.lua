--剣の王 フローディ
--Fraudir, Generaid of the Sword
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_series={0x134}
function s.cfilter(c)
	return c:IsSetCard(0x134) or c:IsRace(RACE_WARRIOR)
end
function s.spcheck(sg,tp)
	return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,#sg,sg)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,s.spcheck,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,99,false,s.spcheck,nil)
	local ct=Duel.Release(g,REASON_COST)
	e:SetLabel(ct)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local ct=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,ct,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
		local g=Duel.GetOperatedGroup()
		g=g:Filter(Card.IsPreviousControler,nil,1-tp)
		if #g>0 and Duel.IsPlayerCanDraw(1-tp,#g) and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Draw(1-tp,#g,REASON_EFFECT)
		end
	end
end