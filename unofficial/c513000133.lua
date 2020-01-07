--Anit the Ray
--Scripted by Keddy
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4004,2))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1131)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_XMATERIAL)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.dcondition)
	e2:SetCost(s.dcost)
	e2:SetTarget(s.dtarget)
	e2:SetOperation(s.doperation)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAnti() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and s.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.cfilter(c,tc)
	return c:IsFaceup() and c:IsAnti() and c~=tc
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if #g>0 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local xg=Group.FromCards(c)
		local xge=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,0,99,tc,c)
		local sg
		xg:Merge(xge)
		for tc in aux.Next(xg) do
			local ov=tc:GetOverlayGroup()
			if not sg then
				sg=ov
			else
				sg=sg+ov
			end
		end
		Duel.SendtoGrave(sg,REASON_RULE)
		Duel.Overlay(tc,xg)
	end
end
function s.dcondition(e,tp,eg,ep,ev,re,r,rp)
	local m0=Duel.GetFieldGroupCount(0,LOCATION_MZONE,0)
	local m1=Duel.GetFieldGroupCount(1,LOCATION_MZONE,0)
	return m0==m1
end
function s.dcfilter(c)
	return c:IsCode(id)
end
function s.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ov=c:GetOverlayGroup()
	if chk==0 then return ov:IsExists(s.dcfilter,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local tov=ov:FilterSelect(tp,s.dcfilter,1,1,nil)
	Duel.SendtoGrave(tov,REASON_COST)
end
function s.dfilter(c)
	return (c:GetAttack()~=c:GetBaseAttack() and c:GetDefense()~=c:GetBaseDefense()) or aux.disfilter1(c)
end
function s.dtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g:Filter(s.dfilter,nil)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,0,0)
end
function s.doperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)		 
	end
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetBaseDefense())
		tc:RegisterEffect(e2)		 
	end	   
end
