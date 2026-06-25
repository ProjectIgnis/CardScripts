--混沌の三幻魔
--Phantasmal Sacred Beasts of Chaos
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 3 Level 10 monsters that cannot be Normal Summoned/Set
	Fusion.AddProcFunRep(c,s.matfilter,3,true)
	--Must be either Fusion Summoned, or Special Summoned (from your Extra Deck) by sending the above cards you control to the GY
	c:AddMustBeFusionSummoned()
	Fusion.AddContactProc(c,s.contactfil,s.contactop,false,nil,1)
	--You can only Special Summon "Phantasmal Sacred Beasts of Chaos" once per turn this way, no matter which method you use
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--The first two times this card would be destroyed by card effect each turn, it is not destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetValue(function(e,re,r) return (r&REASON_EFFECT)>0 end)
	c:RegisterEffect(e1)
	--Once per Chain and thrice per turn (Quick Effect): You can target 1 face-up monster your opponent controls; negate its effects (until the end of this turn), then you can gain LP equal to half its ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(3)
	e2:SetCost(Cost.SoftOncePerChain(id))
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.matfilter(c)
	return c:IsLevel(10) and not c:IsSummonableCard()
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL)
end
function s.regcon(e)
	local c=e:GetHandler()
	return c:IsFusionSummoned() or c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--You can only Special Summon "Phantasmal Sacred Beasts of Chaos" once per turn this way, no matter which method you use
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsOriginalCode(id) and (sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsNegatableMonster() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local tc=Duel.SelectTarget(tp,Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.floor(tc:GetAttack()/2))
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		--Negate its effects (until the end of this turn)
		tc:NegateEffects(e:GetHandler(),RESETS_STANDARD_PHASE_END)
		Duel.AdjustInstantly(tc)
		local lp=math.floor(tc:GetAttack()/2)
		if lp>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
			Duel.BreakEffect()
			Duel.Recover(p,lp,REASON_EFFECT)
		end
	end
end