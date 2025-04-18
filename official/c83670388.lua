--氷水呪縛
--Icejade Curse
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Prevent the activation of monster's effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.accon)
	e2:SetValue(s.aclim)
	c:RegisterEffect(e2)
	--Inflict damage
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
s.listed_names={7142724}
s.listed_series={SET_ICEJADE}
function s.accon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ICEJADE),0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and (Duel.IsEnvironment(7142724)
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,7142724),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil))
end
function s.aclim(e,re,tp)
	local rc=re:GetHandler()
	local status=STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN
	return re:IsMonsterEffect() and rc:IsLocation(LOCATION_MZONE) and rc:IsStatus(status)
end
function s.damcfilter(c,tp,ct)
	local bc=c:GetBattleTarget()
	return (c:IsPreviousControler(tp) and c:IsPreviousSetCard(SET_ICEJADE))
		or (ct==1 and bc and bc:IsControler(tp) and bc:IsSetCard(SET_ICEJADE))
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.damcfilter,1,nil,tp,#eg)
end
function s.damtgfilter(c,e)
	return c:IsCanBeEffectTarget(e) and c:GetBaseAttack()>0 and not c:IsType(TYPE_TOKEN)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.damtgfilter(chkc,e) end
	if chk==0 then return eg:IsExists(s.damtgfilter,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=eg:FilterSelect(tp,s.damtgfilter,1,1,nil,e)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tg:GetFirst():GetBaseAttack())
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:GetBaseAttack()>0 then
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end