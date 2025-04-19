--クリスタルクリアウィング・オーバー・シンクロ・ドラゴン
--Crystal Clear Wing Over Synchro Dragon
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 2+ Tuners or 1 Tuner Synchro Monster + "Clear Wing Synchro Dragon"
	local synchro_proc0=Synchro.AddProcedure(c,nil,2,99,aux.FilterSummonCode(82044279),1,1)
	local synchro_proc1=Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,1,aux.FilterSummonCode(82044279),1,1)
	synchro_proc0:SetDescription(aux.Stringid(id,0))
	synchro_proc1:SetDescription(aux.Stringid(id,1))
	c:AddMustBeSynchroSummoned()
	--Negate the activation of another card or effect and destroy it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) end)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Special Summon 1 "Clear Wing" monster from your Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Multiple Tuner check
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
end
s.material={82044279}
s.listed_names={82044279} --"Clear Wing Synchro Dragon"
s.listed_series={SET_CLEAR_WING}
s.synchro_nt_required=1
s.synchro_tuner_required=1
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc~=e:GetHandler() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if rc:IsRelateToEffect(re) and rc:IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		local atk=rc:IsMonster() and rc:GetTextAttack() or 0
		if atk<0 then atk=0 end
		local c=e:GetHandler()
		if Duel.Destroy(rc,REASON_EFFECT)>0 and atk>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
			--This card gains ATK equal to that monster's original ATK until the end of this turn
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsSynchroSummoned() and c:IsPreviousControler(tp) and rp==1-tp
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_CLEAR_WING) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_MULTIPLE_TUNERS)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD)|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end