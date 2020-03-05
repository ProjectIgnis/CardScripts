--究極伝導恐獣
--Ultimate Conductor Tyranno
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--attack all
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--to grave
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
function s.sprfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #rg>1 and aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),0)
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.filter(c)
	return not c:IsPublic() or c:IsType(TYPE_MONSTER)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	local dg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,TYPE_MONSTER)
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_HAND+LOCATION_MZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,TYPE_MONSTER)
	if #g1>0 and Duel.Destroy(g1,REASON_EFFECT)~=0 then
		local g2=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
		if #g2>0 then
			Duel.ChangePosition(g2,POS_FACEDOWN_DEFENSE)
		end
	end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=Duel.GetAttackTarget()
	if chk ==0 then return Duel.GetAttacker()==e:GetHandler() and d and d:IsDefensePos() end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,d,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Damage(1-tp,1000,REASON_EFFECT)~=0 then
		local d=Duel.GetAttackTarget()
		if d:IsRelateToBattle() and d:IsDefensePos() then
			Duel.SendtoGrave(d,REASON_EFFECT)
		end
	end
end
