--絶望狂魔デッド・ロック
--Dead Lock the Mad Fiend of Despair
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Tributed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Level 5 or higher monsters need a tribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_LIMIT_SET_PROC)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetCondition(s.nsumcon)
	e3:SetTarget(aux.FieldSummonProcTg(s.nsumtg,s.nsumcost))
	e3:SetOperation(s.nsumop)
	e3:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e3)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRaceExcept,RACE_FIEND))
	e2:SetValue(-1000)
	c:RegisterEffect(e2)
end
function s.nsumcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,0,nil)
	local nt=1
	if c:IsLevelAbove(7) then nt=2 end
	return aux.SelectUnselectGroup(rg,e,tp,nt,nt,aux.ChkfMMZ(1),0)
end
function s.nsumtg(e,c)
	return c:IsLevelAbove(5)
end
function s.nsumcost(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local nt=1
	if c:IsLevelAbove(7) then nt=2 end
	local rg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,nt,nt,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.nsumop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.Release(g,REASON_COST|REASON_SUMMON|REASON_MATERIAL)
	g:DeleteGroup()
end