--ゴーストリック・マスター アルカード
--Ghostrick Master Alucard
--Scripted by Eerie Code
local s,id=GetID()
local GHOSTRICK_ALUCARD=75367227
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 6 monsters, OR 1 "Ghostrick Alucard" you control (transfer its materials) by discarding 1 "Ghostrick" card
	Xyz.AddProcedure(c,nil,6,3,s.altprocfilter,aux.Stringid(id,0),3,s.xyzop)
	--Cannot be used as material for an Xyz Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--This face-up card cannot be changed to face-down Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_TURN_SET)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
	--Once per turn (Quick Effect): You can detach 1 material from this card; destroy all face-down cards your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.AND(Cost.DetachFromSelf(1),Cost.HintSelectedEffect))
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
	--When a Spell/Trap Card is activated (Quick Effect): You can detach 2 materials from this card; negate the activation, and if you do, Set that card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_POSITION+CATEGORY_SET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetCost(Cost.AND(Cost.DetachFromSelf(2),Cost.HintSelectedEffect))
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
s.listed_names={GHOSTRICK_ALUCARD}
s.listed_series={SET_GHOSTRICK}
function s.altprocfilter(c,tp,xyzc)
	return c:IsSummonCode(xyzc,SUMMON_TYPE_XYZ,tp,GHOSTRICK_ALUCARD) and c:IsFaceup()
end
function s.discardfilter(c)
	return c:IsSetCard(SET_GHOSTRICK) and c:IsDiscardable()
end
function s.xyzop(e,tp,chk,mc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.discardfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local sc=Duel.GetMatchingGroup(s.discardfilter,tp,LOCATION_HAND,0,nil):SelectUnselect(Group.CreateGroup(),tp,false,Xyz.ProcCancellable)
	return sc and Duel.SendtoGrave(sc,REASON_DISCARD|REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsSpellTrapEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,1,tp,POS_FACEDOWN)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and rc:IsSSetable(true) then
		rc:CancelToGrave()
		Duel.ChangePosition(rc,POS_FACEDOWN)
		rc:SetStatus(STATUS_ACTIVATE_DISABLED,false)
		Duel.RaiseEvent(rc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end