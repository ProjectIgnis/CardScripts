--キャッスル・オブ・ヴァンパイア
--Castle of Vampire
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: Special Summon 1 DARK Zombie monster from your Deck or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--That monster is unaffected by the activated effects of other non-DARK monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(function(e,c)
		return c==e1:GetLabelObject() and c:HasFlagEffect(id)
	end)
	e2:SetValue(function(e,te)
		return te:IsActivated() and te:IsMonsterEffect() and not te:IsCardAttribute(ATTRIBUTE_DARK) and te:GetOwner()~=e1:GetLabelObject()
	end)
	c:RegisterEffect(e2)
	--If this face-up card leaves the field: Destroy as many cards you control as possible, and if you do, take 400 damage for each card destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsPreviousPosition(POS_FACEUP)
	end)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		e:SetLabelObject(nil)
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		e:SetLabelObject(sc)
		local c=e:GetHandler()
		c:SetCardTarget(sc)
		sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_LEAVE|RESET_TEMP_REMOVE|RESET_TOFIELD),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		--When that monster leaves the field, destroy this card
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetCode(EVENT_LEAVE_FIELD_P)
		e0:SetRange(LOCATION_SZONE)
		e0:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
			return eg:IsContains(sc) and sc:HasFlagEffect(id)
		end)
		e0:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetRange(LOCATION_SZONE)
			e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				Duel.Destroy(e:GetHandler(),REASON_EFFECT)
				e0:Reset()
				e1:Reset()
			end)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e1)
		end)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e0)
	else
		e:SetLabelObject(nil)
	end
	Duel.SpecialSummonComplete()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,tp,#g*400)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local destroy_count=#Duel.GetOperatedGroup()
		if destroy_count>0 then
			Duel.Damage(tp,400*destroy_count,REASON_EFFECT)
		end
	end
end