--魂を刻む右
--Soul Fist
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a Dragon Synchro Monster you control
	aux.AddEquipProcedure(c,0,s.eqfilter)
	--A "Red Dragon Archfiend" equipped with this card is unaffected by your opponent's activated effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.immcon)
	e1:SetValue(function(e,te) return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated() end)
	c:RegisterEffect(e1)
	--Change the ATK of all monsters your opponent currently controls to the equipped monster's
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.oppatktg)
	e2:SetOperation(s.oppatkop)
	c:RegisterEffect(e2)
	--Banish 1 monster from your opponent's GY, and if you do, the equipped monster gains ATK equal to the banished monster's
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e) return e:GetHandler():GetEquipTarget():IsRelateToBattle() end)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_RED_DRAGON_ARCHFIEND}
function s.eqfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
function s.immcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(CARD_RED_DRAGON_ARCHFIEND)
end
function s.oppatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ec=e:GetHandler():GetEquipTarget()
		return ec and Duel.IsExistingMatchingCard(aux.FaceupFilter(aux.NOT(Card.IsAttack),ec:GetAttack()),tp,0,LOCATION_MZONE,1,nil)
	end
end
function s.oppatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=c:GetEquipTarget():GetAttack()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(aux.NOT(Card.IsAttack),atk),tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	for tc in g:Iter() do
		--Change its ATK to the equipped monster's
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE) and c:IsMonster() and c:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsMonster,Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsMonster,Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local atk=tc:GetAttack()
		if atk<=0 then return end
		local c=e:GetHandler()
		--The equipped monster gains ATK equal to the banished monster's, until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:GetEquipTarget():RegisterEffect(e1)
	end
end