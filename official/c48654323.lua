--凶導の白聖骸
--White Relic of Dogmatika
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Gain ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e)return e:GetHandler():IsRitualSummoned()end)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Send to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
s.listed_names={60921537}
s.listed_series={SET_DOGMATIKA}
function s.atkrescon(sg)
	return sg:IsExists(Card.IsAttackAbove,1,nil,1)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanBeEffectTarget,e),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>1 and s.atkrescon(g) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.atkrescon,1,tp,HINTMSG_ATKDEF)
	Duel.SetTargetCard(tg)
end
function s.atkfilter(c,g)
	return (g-c):GetFirst():IsAttackAbove(1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if #tg~=2 or not s.atkrescon(tg) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=tg:FilterSelect(tp,s.atkfilter,1,1,nil,tg):GetFirst()
	if tc then
		Duel.HintSelection(tc,true)
		--Update ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue((tg-tc):GetFirst():GetAttack())
		tc:RegisterEffect(e1)
	end
end
function s.indtg(e,c)
	return c:IsSetCard(SET_DOGMATIKA) and c:IsLevelAbove(8)
end
function s.tgconfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsPreviousControler(1-tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tgconfilter,1,nil,tp)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_EXTRA)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g<1 then return end
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:FilterSelect(tp,aux.AND(Card.IsMonster,Card.IsAbleToGrave),1,1,nil)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
		Duel.ShuffleExtra(1-tp)
	end
end