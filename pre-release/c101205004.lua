--ミレニアムーン・メイデン
--Millenniumoon Maiden
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Neither monster can be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indestg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Place this card face-up in your Spell & Trap Zone as a Continuous Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end end)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
	--Special Summon this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and e:GetHandler():IsContinuousSpell() end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		--Treated as a Continuous Spell
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
		c:RegisterEffect(e1)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Your opponent cannot target Level 5 or higher Illusion and Spellcaster monsters you control with card effects this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(function(e,c) return c:IsLevelAbove(5) and c:IsRace(RACE_ILLUSION|RACE_SPELLCASTER) end)
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
	end
end