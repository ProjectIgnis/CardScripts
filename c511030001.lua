--フレキシブル・テンタクラスター
--Flexible Tentacluster
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--no dmg
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	--ss banish
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
s.listed_series={0x570}
function s.op(e,tp,eg,ep,ev,re,r,rp,rc)
	local ba=Duel.GetAttacker()
	local bt=Duel.GetAttackTarget()
	if ((ba and ba:IsSetCard(0x570) and ba:IsControler(tp))
	or (bt and bt:IsSetCard(0x570) and bt:IsControler(tp)))
	and ep==tp and e:GetHandler():GetFlagEffect(id)==0 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_CARD,0,id)
		Duel.ChangeBattleDamage(tp,0)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x570) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		Duel.SendtoGrave(tc,REASON_RULE+REASON_RETURN)
		return
	end
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		c:SetCardTarget(tc)
	end
end
function s.desfilter(c,rc)
	return rc:IsHasCardTarget(c)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	Duel.Destroy(g,REASON_EFFECT)
end