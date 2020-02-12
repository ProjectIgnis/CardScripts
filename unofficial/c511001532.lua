--Rebirth of the Seven Emperors
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x1048}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	return at and at:IsFaceup() and at:IsControler(tp) and at:IsType(TYPE_XYZ)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetFlagEffect(511001531)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_XYZ)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return e:IsHasType(EFFECT_TYPE_ACTIVATE) and #sg>0 and sg:FilterCount(Card.IsReleasable,nil)==#sg 
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp)  end
	local ct=Duel.Release(sg,REASON_COST)
	Duel.SetTargetParam(ct+1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.atfilter(c)
	local class=c:GetMetatable(true)
	if class==nil then return false end
	local no=class.xyz_number
	return no and no>=101 and no<=107 and c:IsFaceup() and c:IsSetCard(0x1048)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local g=Duel.GetMatchingGroup(s.atfilter,tp,LOCATION_REMOVED,0,nil)
		if #g>0 then
			if #g>ct then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
				g=g:Select(tp,ct,ct,nil)
			end
			Duel.BreakEffect()
			Duel.Overlay(tc,g)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
			e2:SetReset(RESET_PHASE+PHASE_BATTLE)
			e2:SetCountLimit(1)
			e2:SetOperation(s.damop)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local dam=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)*300
	Duel.Damage(tp,dam,REASON_EFFECT)
	dam=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)*300
	Duel.Damage(1-tp,dam,REASON_EFFECT)
end
