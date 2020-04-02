--メールの階段
--Stairs of Mail
--Anime version scripted by AlphaKretin
--Name handling adapted from サイバネット・コーデック Cynet Codec by EerieCode
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--change position
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	--register names
	if not s.global_flag then
		s.global_flag=true
		s.name_list={}
		s.name_list[0]={}
		s.name_list[1]={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE+PHASE_END)
		ge1:SetCountLimit(1)
		ge1:SetCondition(s.resetop)
		Duel.RegisterEffect(ge1,0)
	end
end
s.listed_series={0x10b}
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	s.name_list[0]={}
	s.name_list[1]={}
	return false
end
function s.cfilter(c,tp)
	return c:IsSetCard(0x10b) and c:IsDiscardable(REASON_EFFECT) and not table.includes(s.name_list[tp],c:GetCode())
end
function s.upfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsCanChangePosition()
end
function s.downfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
function s.posfilter(c)
	return s.upfilter(c) or s.downfilter(c)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) and 
		Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local dc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if dc and Duel.SendtoGrave(dc,REASON_DISCARD+REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		table.insert(s.name_list[tp],dc:GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local tc=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if not tc then return end
		local pos
		if s.upfilter(tc) then --cannot satisfy both by game rules, or neither because it was a valid selection
			pos=POS_FACEUP_ATTACK
		else 
			pos=POS_FACEDOWN_DEFENSE
		end
		Duel.ChangePosition(tc,pos)
	end
end
if not table.includes then
	--binary search
	function table.includes(t,val)
		if #t<1 then return false end
		if #t==1 then return t[1]==val end --saves sorting for efficiency
		table.sort(t)
		local left=1
		local right=#t
		while left<=right do
			local middle=(left+right)//2
			if t[middle]==val1 then return true
			elseif t[middle]<val then left=middle+1
			else right=middle-1 end
		end
		return false
	end
end

