--ゴッド・ブレイズ・キャノン
--Blaze Cannon
--Logical Nonsense
local s,id=GetID()
function s.initial_effect(c)
	--Grant multiple effects to 1 "The Winged Dragon of Ra"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(TIMING_STANDBY_PHASE|TIMING_BATTLE_START)
	c:RegisterEffect(e1)
end
	--Specifically lists "The Winged Dragon of Ra"
s.listed_names={CARD_RA}
	--Check for "The Winged Dragon of Ra"
function s.selfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_RA) and c:GetFlagEffect(id)==0
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.selfilter,tp,LOCATION_MZONE,0,1,nil) end
end
	--Grant multiple effects to 1 "The Winged Dragon of Ra"
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local tc=Duel.SelectMatchingCard(tp,s.selfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc,true)
	if tc:GetFlagEffect(id)==0 then
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
		--Unaffected by opponent's card effects
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(3110)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.efilter)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Tribute any number of other monsters; gain ATK equal to the combined ATK of the tributed monsters
		local e2=Effect.CreateEffect(tc)
		e2:SetCategory(CATEGORY_ATKCHANGE)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(s.atkcon)
		e2:SetCost(s.atkcost)
		e2:SetOperation(s.atkop)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
		--After damage calculation, send all opponent's monsters to GY
		local e3=Effect.CreateEffect(tc)
		e3:SetCategory(CATEGORY_TOGRAVE)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_BATTLED)
		e3:SetCondition(s.sendcon)
		e3:SetTarget(s.sendtg)
		e3:SetOperation(s.sendop)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e3)
	end
end
	--Unaffected by opponent's card effects
function s.efilter(e,re)
	return e:GetOwnerPlayer()==1-re:GetOwnerPlayer()
end
	--Check that an attack involving "The Winged Dragon of Ra" was declared
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c or (Duel.GetAttackTarget() and Duel.GetAttackTarget()==c)
end
	--Check for monsters that did not attack
function s.atkfilter(c,tp)
	return c:GetAttackAnnouncedCount()==0 and c:GetTextAttack()>0 and (c:IsControler(tp) or c:IsFaceup())
end
	--Tribute cost
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.atkfilter,1,false,nil,e:GetHandler(),tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.atkfilter,1,99,false,nil,e:GetHandler(),tp)
	local ct=Duel.Release(g,REASON_COST)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
	--Gain ATK equal to the combined ATK of the tributed monsters
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g then return end
	local atk=0
	for tc in g:Iter() do
		local batk=tc:GetTextAttack()
		if batk>0 then
			atk=atk+batk
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
	e:GetHandler():RegisterEffect(e1)
	g:DeleteGroup()
end
	--If this card attacked
function s.sendcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler()
end
	--Activation legality
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0,LOCATION_MZONE)
end
	--After damage calculation, send all opponent's monsters to GY
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
end