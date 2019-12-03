--フォッグ・コントロール
--Fog COntrol
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.counter_place_list={0x1019}
s.listed_series={0x18}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18)
end
function s.filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,aux.ReleaseCheckTarget,nil,dg) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,aux.ReleaseCheckTarget,nil,dg)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1019,3)
	end
end
