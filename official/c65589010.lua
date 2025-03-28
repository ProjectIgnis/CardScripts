--教導国家ドラグマ
--Dogmatika Nation
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_DOGMATIKA))
	e2:SetValue(s.tgval)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--Send to the graveyard
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.gycon)
	e4:SetTarget(s.gytg)
	e4:SetOperation(s.gyop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_DOGMATIKA}
function s.tgval(e,re,rp)
	return re:IsMonsterEffect() and re:GetHandler():IsSpecialSummoned() and re:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
function s.check(c,tp)
	return c and c:IsControler(tp) and c:IsSetCard(SET_DOGMATIKA)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttackTarget()~=nil
		and (s.check(Duel.GetAttacker(),tp) or s.check(Duel.GetAttackTarget(),tp)) end
	if s.check(Duel.GetAttacker(),tp) then
		Duel.SetTargetCard(Duel.GetAttackTarget())
	else
		Duel.SetTargetCard(Duel.GetAttacker())
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0) * Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA) > 0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,PLAYER_ALL,LOCATION_EXTRA)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Group.CreateGroup()
	for p=0,1 do
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(p,Card.IsAbleToGrave,p,LOCATION_EXTRA,0,1,1,nil)
		if #g>0 then
			sg:AddCard(g:GetFirst())
		end
	end
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end