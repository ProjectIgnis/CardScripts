--埋葬されし生け贄 (Anime)
--Tribute Burial (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCondition(s.otcon)
	e1:SetTarget(aux.FieldSummonProcTg(s.ottg,s.sumtg))
	e1:SetOperation(s.otop)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	Duel.RegisterEffect(e2,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end
function s.rmfilter(c)
	return c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c)
end
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil)
end
function s.ottg(e,c)
	local mi=c:GetTributeRequirement()
	return mi>0
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,c)
	local mg1=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local mg2=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,nil)
	::restart::
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local g1=mg1:Select(tp,1,1,true,nil)
	if not g1 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local tc=mg2:SelectUnselect(g1,tp,false,false,2,2)
	if mg2:IsContains(tc) then
		g1:AddCard(tc)
		g1:KeepAlive()
		e:SetLabelObject(g1)
		return true
	end
	goto restart
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	sg:DeleteGroup()
	Duel.ResetFlagEffect(tp,id)
end