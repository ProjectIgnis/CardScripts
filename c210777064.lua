--The Beast That Lurks in the Ashes
--designed by Thaumablazer#4134, scripted by Naim
--local s,id=GetID()
function c210777064.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,210777064)
	e1:SetCondition(c210777064.spcon)
	e1:SetOperation(c210777064.spop)
	c:RegisterEffect(e1)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c210777064.efilter)
	c:RegisterEffect(e2)
	--gy effect (burn)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,210777064+100)
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c210777064.dmgcond)
	e3:SetTarget(c210777064.dmgtg)
	e3:SetOperation(c210777064.dmgop)
	c:RegisterEffect(e3)
end
function c210777064.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,c)
end
function c210777064.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function c210777064.efilter(e,re)
	local cg=e:GetHandler():GetColumnGroup()
	local typecheck=0
	for tc in aux.Next(cg) do
		typecheck = typecheck | (tc:GetType()&(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP))
	end
	return typecheck~=0 and re:IsActiveType(typecheck)
end
function c210777064.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf10) and not c:IsCode(210777064)
end
function c210777064.dmgcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210777064.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c210777064.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
 	if chk==0 then return true end
	local ct=Duel.GetFieldGroupCount(tp,0xc,0xc)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
function c210777064.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetFieldGroupCount(tp,0xc,0xc)
	Duel.Damage(p,ct*200,REASON_EFFECT)
end

