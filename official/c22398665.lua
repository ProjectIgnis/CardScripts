--流星輝巧群
--Meteonis Drytron
--Scripted by Eerie Code and edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	Ritual.AddProcGreater({handler=c,filter=s.ritualfil,lv=Card.GetAttack,matfilter=s.filter,location=LOCATION_HAND|LOCATION_GRAVE,requirementfunc=Card.GetAttack,desc=aux.Stringid(id,0)})
	--Add itself to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DRYTRON}
function s.ritualfil(c)
	return c:GetAttack()>0 and c:IsRitualMonster()
end
function s.filter(c)
	return c:IsRace(RACE_MACHINE) and c:GetAttack()>0
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DRYTRON) and c:GetAttack()>=1000
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToHand() and Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:UpdateAttack(-1000,RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN,c)==-1000
		and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end