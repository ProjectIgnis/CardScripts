--天魔神 ノーレラス
--Sky Scourge Norleras
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--to grave
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.sgcost)
	e3:SetTarget(s.sgtg)
	e3:SetOperation(s.sgop)
	c:RegisterEffect(e3)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.atchk1,1,nil,sg)
end
function s.atchk1(c,sg)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and sg:FilterCount(s.atchk2,c)==3
end
function s.atchk2(c,sg)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)
end
function s.spfilter(c,att,race)
	return c:IsAttribute(att) and c:IsRace(race) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT,RACE_FAIRY)
	local rg2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK,RACE_FIEND)
	local rg=rg1:Clone()
	rg:Merge(rg2)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-4 and #rg1>0 and #rg2>2 
		and aux.SelectUnselectGroup(rg,e,tp,4,4,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT,RACE_FAIRY)
	rg:Merge(Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK,RACE_FIEND))
	local g=aux.SelectUnselectGroup(rg,e,tp,4,4,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
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
function s.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local g=Duel.GetFieldGroup(tp,0xe,0xe)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,0,0,tp,1)
end
function s.sgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0xe,0xe)
	Duel.SendtoGrave(g,REASON_EFFECT)
	Duel.Draw(tp,1,REASON_EFFECT)
end
