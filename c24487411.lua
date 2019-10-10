--デトネイト・デリーター
--Detonate Deleter
--scripted by andré
local s, id = GetID()
function s.initial_effect(c)
	--must be first link summoned (implied)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),2,3)
	--battle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCountLimit(1)
	e1:SetTarget(s.dtarget)
	e1:SetOperation(s.doperation)
	c:RegisterEffect(e1)
	--tribute and destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.tdcost)
	e2:SetTarget(s.tdtarget)
	e2:SetOperation(s.tdoperation)
	c:RegisterEffect(e2)
end
function s.dtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and not (tc:IsLinkMonster() and tc:IsLinkAbove(3)) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,tc:GetControler(),LOCATION_MZONE)
end
function s.doperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if tc==c then tc=Duel.GetAttackTarget() end
	if tc:IsRelateToBattle() then Duel.Destroy(tc,REASON_EFFECT) end
end
function s.cfilter(c,tp,cg)
	return cg:IsContains(c) and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,c)
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=c:GetLinkedGroup()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,tp,cg) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,tp,cg)
	Duel.Release(g,REASON_COST)
end
function s.tdtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,1-tp,LOCATION_MZONE)
end
function s.tdoperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

