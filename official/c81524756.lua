--天穹のパラディオン
--Crusadia Maximus
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetValue(s.spval)
	c:RegisterEffect(e1)
	--Make 1 "Crusadia" link monster deal double battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.dbcon)
	e2:SetTarget(s.dbtg)
	e2:SetOperation(s.dbop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CRUSADIA}
function s.spval(e,c)
	return 0,aux.GetMMZonesPointedTo(c:GetControler())
end
function s.dbcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.dbfilter(c)
	return c:IsFaceup() and c:IsLinkMonster() and c:IsSetCard(SET_CRUSADIA)
end
function s.dbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.dbfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dbfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.dbfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.dbop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		--Deal double battle damage
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3209)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetCondition(s.damcon)
		e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Your other monsters cannot attack
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(s.ftarget)
		e2:SetLabel(tc:GetFieldID())
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
function s.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end