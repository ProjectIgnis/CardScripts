--サークル・オブ・フェアリー
--Circle of the Fairies
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Additional Normal Summon for Insect or Plant monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT|RACE_PLANT))
	c:RegisterEffect(e1)
	--Inflict damage equal to half of the target and recover the same amount
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
function s.damcfilter(c,tp)
	local rc=c:GetReasonCard()
	if not (c:IsLocation(LOCATION_GRAVE) and rc) then return false end
	if c:IsPreviousControler(tp) then
		local prev_race=c:GetPreviousRaceOnField()
		return prev_race&RACE_INSECT>0 or prev_race&RACE_PLANT>0
	else
		if rc:IsRelateToBattle() then
			return rc:IsControler(tp) and rc:IsRace(RACE_INSECT|RACE_PLANT)
		else
			local prev_race=rc:GetPreviousRaceOnField()
			return rc:IsPreviousControler(tp) and (prev_race&RACE_INSECT>0 or prev_race&RACE_PLANT>0)
		end
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.damcfilter,1,nil,tp)
end
function s.damtgfilter(c,e)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCanBeEffectTarget(e) and c:GetPreviousAttackOnField()>0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.damtgfilter(chkc,e) end
	if chk==0 then return eg:IsExists(s.damtgfilter,1,nil,e) end
	local tg=eg
	if #eg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tg=eg:FilterSelect(tp,s.damtgfilter,1,1,nil,e)
	end
	Duel.SetTargetCard(tg)
	local value=tg:GetFirst():GetPreviousAttackOnField()/2
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,value)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,value)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local value=Duel.Damage(1-tp,tc:GetPreviousAttackOnField()/2,REASON_EFFECT)
	if value>0 then
		Duel.BreakEffect()
		Duel.Recover(tp,value,REASON_EFFECT)
	end
end
