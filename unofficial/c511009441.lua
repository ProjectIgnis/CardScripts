--覇王龍ズァーク (Anime)
--Supreme King Z-ARC (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	--fusion proc
	local fe=Effect.CreateEffect(c)
	fe:SetType(EFFECT_TYPE_SINGLE)
	fe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	fe:SetCode(EFFECT_FUSION_MATERIAL)
	fe:SetCondition(s.fscon)
	c:RegisterEffect(fe)
	s.min_material_count=0
	s.max_material_count=0
	--level/rank
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_RANK_LEVEL_S)
	c:RegisterEffect(e0)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--destroy and damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCost(s.damcost)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--indestructable/immune
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE)
	e4:SetCondition(s.indcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(s.imfilter)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e6:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_RITUAL))
	c:RegisterEffect(e6)
	--immune to Fusion/Synchro/Xyz
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetValue(s.efilter)
	c:RegisterEffect(e7)
	--special summon SK dragon
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_BATTLE_DESTROYING)
	e8:SetCondition(aux.bdocon)
	e8:SetTarget(s.sptg2)
	e8:SetOperation(s.spop2)
	c:RegisterEffect(e8)
	--destroy drawn
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,3))
	e9:SetCategory(CATEGORY_DESTROY)
	e9:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e9:SetCode(EVENT_TO_HAND)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCondition(s.descon)
	e9:SetTarget(s.destg)
	e9:SetOperation(s.desop)
	c:RegisterEffect(e9)
end
s.listed_series={SET_SUPREME_KING,SET_SUPREME_KING_DRAGON}
s.listed_names={76794549}
function s.fscon(e,g,gc,chkfnf)
	if g==nil then return true end
	return false
end
function s.splimit(e,se,sp,st)
	local code=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE)
	return se:GetHandler():IsCode(76794549) or code==76794549
end
function s.cfilter(c,ft,tp)
	return c:IsSetCard(SET_SUPREME_KING) and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,aux.ReleaseCheckMMZ,nil,SET_SUPREME_KING) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,false,aux.ReleaseCheckMMZ,nil,SET_SUPREME_KING)
	Duel.Release(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e1,true)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local dg=Duel.GetOperatedGroup()
		Duel.BreakEffect()
		local dam=dg:GetSum(Card.GetPreviousAttackOnField)
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
function s.indfilter(c,tpe)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(tpe)
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.indfilter,0,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_GRAVE|LOCATION_REMOVED,1,nil,TYPE_FUSION)
		and Duel.IsExistingMatchingCard(s.indfilter,0,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_GRAVE|LOCATION_REMOVED,1,nil,TYPE_SYNCHRO)
		and Duel.IsExistingMatchingCard(s.indfilter,0,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_GRAVE|LOCATION_REMOVED,1,nil,TYPE_XYZ)
end
function s.leaveChk(c,category)
	local ex,tg=Duel.GetOperationInfo(0,category)
	return ex and tg~=nil and tg:IsContains(c)
end
function s.imfilter(e,te)
	local c=e:GetOwner()
	return (c:GetDestination()>0 and c:GetReasonEffect()==te)
		or (s.leaveChk(c,CATEGORY_TOHAND) or s.leaveChk(c,CATEGORY_DESTROY) or s.leaveChk(c,CATEGORY_REMOVE)
		or s.leaveChk(c,CATEGORY_TODECK) or s.leaveChk(c,CATEGORY_RELEASE) or s.leaveChk(c,CATEGORY_TOGRAVE))
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.spfilter(c,e,tp,rp)
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,rp,nil,c)<=0 then return false end
	return c:IsSetCard(SET_SUPREME_KING_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return loc~=0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,2,nil,e,tp,rp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_EXTRA)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,2,2,nil,e,tp,rp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsControler(1-tp)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.desfilter,nil,e,tp)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end