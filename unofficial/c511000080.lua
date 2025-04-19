--コールド・スリーパー
--Cold Sleeper
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(s.cfilter,1,nil,e,tp) end
	local dis=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	e:SetLabel(dis)
	Duel.SetTargetCard(eg:Filter(s.cfilter,nil,e,tp))
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(function() return e1:GetLabel() end)
	Duel.RegisterEffect(e1,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		aux.DelayedOperation(tc,PHASE_BATTLE,id,e,tp,s.op)
	end
end
function s.op(ag,e,tp)
	local tc=ag:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- Cannot change its battle position
		local e1=Effect.CreateEffect(e:GetOwner())
		e1:SetDescription(3313)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end