--獣神機王バルバロスUr
--Beast Machine King Barbaros Ür
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--no battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.atchk1,1,nil,sg)
end
function s.atchk1(c,sg)
	return c:IsRace(RACE_MACHINE) and sg:FilterCount(s.atchk2,c)==1
end
function s.atchk2(c)
	return c:IsRace(RACE_BEASTWARRIOR)
end
function s.spfilter(c,rac)
	return c:IsRace(rac) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,true)
end
function s.spcon(e,c)
	local c=e:GetHandler()
	if c==nil then return true end
	local tp=c:GetControler()
	local rg1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,c,RACE_MACHINE)
	local rg2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,c,RACE_BEASTWARRIOR)
	local rg=rg1:Clone()
	rg:Merge(rg2)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #rg1>0 and #rg2>0 
		and aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,c,RACE_MACHINE)
	rg:Merge(Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,c,RACE_BEASTWARRIOR))
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end