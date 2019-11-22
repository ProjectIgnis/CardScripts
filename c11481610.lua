--EMポップアップ
--Performapal Pop-Up
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x9f,0x99,0x98}
function s.costchk(sg,e,tp)
	return Duel.IsPlayerCanDraw(tp,#sg)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,nil)
	if chk==0 then 
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return aux.SelectUnselectGroup(g,e,tp,1,3,s.costchk,0) 
	end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,s.costchk,1,tp,HINTMSG_TOGRAVE)
	local ct=Duel.SendtoGrave(sg,REASON_COST)
	e:SetLabel(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.spfilter(c,e,tp,ls,rs)
	return ((c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)) or c:IsSetCard(0x99) or c:IsSetCard(0x9f))
		and c:GetLevel()>ls and c:GetLevel()<rs
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if Duel.Draw(tp,ct,REASON_EFFECT)==0 then return end
	local summoned=false
	local pc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local pc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if pc1 and pc2 and pc1:IsFaceup() and pc2:IsFaceup() then
		local ls,rs=pc1:GetLeftScale(),pc2:GetRightScale()
		if ls>rs then ls,rs=rs,ls end
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp,ls,rs)
		local lc=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if #g>0 and lc>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(ct,lc),aux.dncheck,1,tp,HINTMSG_SPSUMMON)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			summoned=true
		end
	end
	if not summoned then
		local lp=Duel.GetLP(tp)-(1000*Duel.GetFieldGroupCount(tp,LOCATION_HAND,0))
		Duel.SetLP(tp,math.max(lp,0))
	end
end

