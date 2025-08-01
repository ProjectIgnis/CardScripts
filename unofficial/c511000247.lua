--極神皇トール (Anime)
--Thor, Lord of the Aesir (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	--Synchro Summon procedure: 1 Tuner monster + 2 or more non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),2,99)
	--Negate the effects of 1 monster your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Register for this card leaving the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	--Special Summon this card during the End Phase when it is destroyed and sent to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30604579,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--If this card is Special Summoned by the above effect, inflict 800 damage to your opponent
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30604579,2))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1) end)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
function s.effdisablefilter(c)
	return c:IsFaceup() and c:IsNegatableMonster()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.effdisablefilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsNegatableMonster),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsNegatableMonster),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		tc:NegateEffects(c,RESETS_STANDARD_PHASE_END)
		if Duel.SelectYesNo(tp,aux.Stringid(10032958,0)) then
			c:CopyEffect(code,RESETS_STANDARD_PHASE_END,1)
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pos=c:GetPreviousPosition()
	if c:IsReason(REASON_BATTLE) then pos=c:GetBattlePosition() end
	if c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) and (pos&POS_FACEUP)>0 then
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,1,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
