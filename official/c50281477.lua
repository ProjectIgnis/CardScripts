--ティスティナの瘴神
--Tainted of the Tistina
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Tribute Summon face-up by tributing 1 monster the opponent controls
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SUMMON_PROC)
	e0:SetCondition(s.sumcon)
	e0:SetTarget(s.sumtg)
	e0:SetOperation(s.sumop)
	e0:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e0)
	--Becomes Level 10
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():IsNormalSummoned() end)
	e1:SetValue(10)
	c:RegisterEffect(e1)
	--"Tistina" monster can make a second attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(function(e) return Duel.IsAbleToEnterBP() and not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TISTINA}
function s.sumcon(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	local tp=c:GetControler()
	if minc>1 or c:IsLevelBelow(4) or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return false end
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFacedown,Card.IsReleasable),tp,0,LOCATION_MZONE,nil)
	local must_g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_MZONE,LOCATION_MZONE,nil,EFFECT_EXTRA_RELEASE)
	return #g>0 and (#must_g==0 or #(g&must_g)>0) 
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFacedown,Card.IsReleasable),tp,0,LOCATION_MZONE,nil)
	local must_g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_MZONE,LOCATION_MZONE,nil,EFFECT_EXTRA_RELEASE)
	if #must_g>0 then g=g&must_g end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local mc=g:Select(tp,1,1,nil):GetFirst()
	if not mc then return false end
	e:SetLabelObject(mc)
	return true
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	local mc=e:GetLabelObject()
	c:SetMaterial(mc)
	Duel.Release(mc,REASON_SUMMON|REASON_MATERIAL)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_TISTINA) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--Can make a second attack
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3201)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
	--Can only attack with 1 monster this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(function(e) return e:GetLabel()~=0 end)
	e1:SetTarget(function(e,c) return c:GetFieldID()~=e:GetLabel() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetLabelObject(e1)
	e2:SetOperation(function(e,_,eg) e:GetLabelObject():SetLabel(eg:GetFirst():GetFieldID()) end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
end