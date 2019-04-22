--光の創造神 ホルアクティ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--spsummon condition
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	--win
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.winop)
	c:RegisterEffect(e4)
end
function s.spfilter(c,code)
	local code1,code2=c:GetOriginalCodeRule()
	return code1==code or code2==code
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.chk,1,nil,sg,Group.CreateGroup(),10000000,10000010,10000020)
end
function s.chk(c,sg,g,code,...)
	local code1,code2=c:GetOriginalCodeRule()
	if code~=code1 and code~=code2 then return false end
	local res
	if ... then
		g:AddCard(c)
		res=sg:IsExists(s.chk,1,g,sg,g,...)
		g:RemoveCard(c)
	else
		res=true
	end
	return res
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp)
	local g1=rg:Filter(s.spfilter,nil,10000000)
	local g2=rg:Filter(s.spfilter,nil,10000010)
	local g3=rg:Filter(s.spfilter,nil,10000020)
	local g=g1:Clone()
	g:Merge(g2)
	g:Merge(g3)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #g1>0 and #g2>0 and #g3>0 
		and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp)
	local g1=rg:Filter(s.spfilter,nil,10000000)
	local g2=rg:Filter(s.spfilter,nil,10000010)
	local g3=rg:Filter(s.spfilter,nil,10000020)
	g1:Merge(g2)
	g1:Merge(g3)
	local sg=aux.SelectUnselectGroup(g1,e,tp,3,3,s.rescon,1,tp,HINTMSG_RELEASE)
	Duel.Release(g1,REASON_COST)
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_CREATORGOD=0x13
	local p=e:GetHandler():GetSummonPlayer()
	Duel.Win(p,WIN_REASON_CREATORGOD)
end
