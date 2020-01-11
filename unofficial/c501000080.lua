--Kuzunoha, the Onmyojin
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--match winner
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	--spsummon condition
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(s.splimit)
	c:RegisterEffect(e3)
	--summon with 3 tribute
	local e4=aux.AddNormalSummonProcedure(c,true,false,3,3)
	local e5=aux.AddNormalSetProcedure(c)
	--tribute limit
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_TRIBUTE_LIMIT)
	e6:SetValue(s.tlimit)
	c:RegisterEffect(e6)
	--match kill
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_MATCH_KILL)
	e7:SetCondition(s.con)
	c:RegisterEffect(e7)
end
s.illegal=true
function s.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_PENDULUM) and c:IsAbleToRemoveAsCost()
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and (not e or c:IsCanBeEffectTarget(e)) 
		and (not tp or Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,3,c))
end
function s.nsfilter(c)
	return not c:IsRace(RACE_SPELLCASTER)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local pentg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e,tp)
	local pct=#pentg
	if chk==0 then return pct>0 end
	local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local g
	if pct==1 then
		sg:Sub(pentg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=sg:Select(tp,3,3,nil)
	elseif pentg:FilterCount(s.nsfilter,nil)>0 or pct>=4 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=sg:Select(tp,3,3,nil)
	elseif pct==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=sg:FilterSelect(tp,Card.IsFacedown,2,2,nil)
		sg:Sub(g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g2=sg:Select(tp,1,1,nil)
		g:Merge(g2)
	elseif pct==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=sg:FilterSelect(tp,Card.IsFacedown,1,1,nil)
		sg:Sub(g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g2=sg:Select(tp,2,2,nil)
		g:Merge(g2)
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MATCH_KILL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.tlimit(e,c)
	return not c:IsRace(RACE_SPELLCASTER)
end
function s.con(e)
	local tp=e:GetHandler():GetControler()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
