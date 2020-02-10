--No.93 希望皇ホープ・カイザー
--Number 93: Utopia Kaiser
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,99,nil,false,s.xyzcheck)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
end
s.listed_series={0x48}
s.xyz_number=93
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsSetCard(0x48,xyz,sumtype,tp) and c:GetOverlayCount()>0
end
function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
	return mg:GetClassCount(Card.GetRank)==1
end
function s.check(c,rk)
	return c:GetRank()~=rk and not c:IsHasEffect(511001175)
end
function s.filter(c,e,tp,rp)
	return c:IsRankBelow(9) and c:IsAttackBelow(3000) and c:IsSetCard(0x48)
		and Duel.GetLocationCountFromEx(tp,rp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,rp)
		and e:GetHandler():GetOverlayCount() > 0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.gfilter(c,rank)
	return c:GetRank()==rank
end
function s.freezoneschk(c,tp,rp)
	return Duel.GetLocationCountFromEx(tp,rp,nil,c)>0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=nil
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
	local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and gate[tp]
	if ect then ft=ft and math.min(ft,ect) or ect end
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,rp)
	local ct=c:GetOverlayGroup():GetClassCount(Card.GetCode)
	if ft and ct>ft then ct=ft end
	if #g1>0 and ct>0 then
		repeat
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g2=g1:Select(tp,1,1,nil)
			local tc=g2:GetFirst()
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			g1:Remove(s.gfilter,nil,tc:GetRank())
			g1=g1:Filter(s.freezoneschk,nil,tp,rp)
			ct=ct-1
		until #g1==0 or ct==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1))
		Duel.SpecialSummonComplete()
		Duel.BreakEffect()
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3:SetCondition(s.dcon)
	e3:SetOperation(s.dop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetTargetRange(1,0)
	Duel.RegisterEffect(e4,tp)
end
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	Duel.HalfBattleDamage(ep)
end
function s.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x48)
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
