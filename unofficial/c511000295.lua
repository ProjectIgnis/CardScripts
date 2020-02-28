--Numeron Chaos Ritual
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=false
		s[1]=false
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.cfilter(c)
	return c:GetPreviousCodeOnField()==511000277
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter,nil)
	local tc=g:GetFirst()
	while tc do
		s[tc:GetPreviousControler()]=true
		tc=g:GetNext()
	end
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=false
	s[1]=false
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return s[tp]
end
function s.filterchk1(c,mg,matg,tp)
	local g=mg:Clone()
	local tg=matg:Clone()
	g:RemoveCard(c)
	tg:AddCard(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_MONSTER)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetValue(12)
	e2:SetReset(RESET_CHAIN)
	c:RegisterEffect(e2)
	local res=g:IsExists(s.filterchk2,1,nil,g,tg,0,tp)
	e1:Reset()
	e2:Reset()
	return res
end
function s.filterchk2(c,mg,matg,ct,tp)
	local g=mg:Clone()
	local tg=matg:Clone()
	g:RemoveCard(c)
	tg:AddCard(c)
	local ctc=ct+1
	local res=false
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetValue(12)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	if ctc==4 then
		res=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,tg)
	else
		res=g:IsExists(s.filterchk2,1,nil,g,tg,ctc,tp)
	end
	e1:Reset()
	return res
end
function s.xyzfilter(c,mg)
	return c:IsXyzSummonable(nil,mg,5,5)
end
function s.matfilter(c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg1=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,0,nil,511000275)
	local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and mg1:IsExists(s.filterchk1,1,nil,mg2,Group.CreateGroup(),tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local matg=Group.CreateGroup()
	local mg1=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,0,nil,511000275)
	local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sg1=mg1:FilterSelect(tp,s.filterchk1,1,1,nil,mg2,matg,tp)
	local tc1=sg1:GetFirst()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_MONSTER)
	e1:SetReset(RESET_CHAIN)
	tc1:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetValue(12)
	e2:SetReset(RESET_CHAIN)
	tc1:RegisterEffect(e2)
	matg:AddCard(tc1)
	mg2:RemoveCard(tc1)
	for i=1,4 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sg2=mg2:FilterSelect(tp,s.filterchk2,1,1,nil,mg2,matg,i-1,tp)
		local tc2=sg2:GetFirst()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_XYZ_LEVEL)
		e2:SetValue(12)
		e2:SetReset(RESET_CHAIN)
		tc2:RegisterEffect(e2)
		matg:AddCard(tc2)
		mg2:RemoveCard(tc2)
	end
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,matg)
	if #xyzg>0 then
		Duel.HintSelection(matg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		Duel.XyzSummon(tp,xyz,nil,matg)
	end
end
