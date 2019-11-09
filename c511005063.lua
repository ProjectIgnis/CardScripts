--Magical Hats (Anime)
--original script by Shad3
local s,id=GetID()
--Jack specific card effects -_-
if not s.gl_chk then
	s.gl_chk=true
	local regeff=Card.RegisterEffect
	Card.RegisterEffect=function(c,e,f)
		local tc=e:GetOwner()
		if tc then
			local tg=e:GetTarget()
			if tg then
				if c35803249 and tg==c35803249.distg then --Jinzo - Lord
					--Debug.Message('"Jinzo - Lord" detected')
					e:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
				elseif c51452091 and tg==c51452091.distarget then --Royal Decree
					--Debug.Message('"Royal Decree" detected')
					e:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
				elseif c77585513 and tg==c77585513.distg then --Jinzo
					--Debug.Message('"Jinzo" detected')
					e:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
				elseif c84636823 and tg==c84636823.distg then --Spell Canceller
					--Debug.Message('"Spell Canceller" detected')
					e:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
				end
			end
		end
		return regeff(c,e,f)
	end
end
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.cd)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.cd(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.fil(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsFaceup()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local n=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return n>0 and Duel.IsExistingTarget(s.fil,tp,LOCATION_MZONE,0,1,nil) end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then n=1 end
	Duel.SelectTarget(tp,s.fil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,n,tp,0)
end
function s.sum_fil(c,e,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),nil,0x11,0,0,0,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local loc=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if loc<1 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then loc=1 end
	local gg=Duel.GetMatchingGroup(s.sum_fil,tp,LOCATION_DECK,0,nil,e,tp)
	local sg=Group.CreateGroup()
	if #gg>0 and Duel.SelectYesNo(tp,aux.Stringid(4001,10)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		sg:Merge(gg:Select(tp,1,loc,nil))
	end
	local sco=loc-#sg
	if sco>0 then
		for i=1,sco do
			sg:AddCard(Duel.CreateToken(tp,511005062))
		end
	end
	local stc=sg:GetFirst()
	while stc do
		local e1=Effect.CreateEffect(stc)
		if stc:IsType(TYPE_SPELL+TYPE_TRAP) then
			local te=stc:GetActivateEffect()
			if te then
				local se1=Effect.CreateEffect(stc)
				se1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
				se1:SetCondition(s.mimica_cd)
				se1:SetCost(s.mimica_cs)
				se1:SetTarget(s.mimica_tg)
				se1:SetOperation(s.mimica_op)
				se1:SetProperty((te:GetProperty()|EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL))
				se1:SetCategory(te:GetCategory())
				se1:SetLabel(te:GetLabel())
				se1:SetLabelObject(te:GetLabelObject())
				se1:SetReset(RESET_EVENT+0x47c0000)
				stc:RegisterEffect(se1)
				local se2=Effect.CreateEffect(stc)
				se2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				se2:SetCode(EVENT_FLIP)
				se2:SetCondition(s.mimica_cd)
				se2:SetOperation(s.mimica_rst)
				se1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
				se1:SetReset(RESET_EVENT+0x47c0000)
				stc:RegisterEffect(se2)
				if stc:IsType(TYPE_TRAP) then
					local te1=Effect.CreateEffect(stc)
					te1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
					te1:SetCode(EVENT_BE_BATTLE_TARGET)
					te1:SetRange(LOCATION_MZONE)
					te1:SetCondition(s.mimicb_cd)
					te1:SetOperation(s.mimicb_op)
					te1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_UNCOPYABLE)
					te1:SetReset(RESET_EVENT+0x47c0000)
					stc:RegisterEffect(te1)
				end
			end
		end
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_NORMAL+TYPE_MONSTER)
		e1:SetReset(RESET_EVENT+0x47c0000)
		stc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_REMOVE_RACE)
		e2:SetValue(RACE_ALL)
		stc:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_REMOVE_ATTRIBUTE)
		e3:SetValue(0xff)
		stc:RegisterEffect(e3,true)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_SET_BASE_ATTACK)
		e4:SetValue(0)
		stc:RegisterEffect(e4,true)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_SET_BASE_DEFENSE)
		e5:SetValue(0)
		stc:RegisterEffect(e5,true)
		stc:SetStatus(STATUS_NO_LEVEL,true)
		stc=sg:GetNext()
	end
	Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEDOWN_DEFENSE)
	if tc:IsFaceup() then
		if tc:IsHasEffect(EFFECT_DEVINE_LIGHT) then Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		else
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
			tc:ClearEffectRelation()
		end
	end
	sg:AddCard(tc)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleSetCard(sg)
end
function s.mimica_cd(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE or (re and e:GetHandler()==re:GetHandler())
end
function s.mimica_rst(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetEffect(EFFECT_CHANGE_TYPE,RESET_CODE)
end
function s.mimica_cs(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	c:AssumeProperty(ASSUME_TYPE,c:GetOriginalType())
	local te=c:GetActivateEffect()
	local tprop=te:GetProperty()
	te:SetProperty((tprop|EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL))
	local act=te:IsActivatable(tp)
	te:SetProperty(tprop)
	if chk==0 then return act end
	e:SetType(EFFECT_TYPE_ACTIVATE)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetOperation(s.mimica_endop)
	c:CreateEffectRelation(e1)
	Duel.RegisterEffect(e1,tp)
	local cost=te:GetCost()
	if cost then cost(te,tp,eg,ep,ev,re,r,rp,1) end
end
function s.mimica_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local te=e:GetHandler():GetActivateEffect()
	local targ=te:GetTarget()
	if chkc then return targ and targ(tp,eg,ep,ev,re,r,rp,0,chkc) end
	if chk==0 then return not targ or targ(te,tp,eg,ep,ev,re,r,rp,0) end
	e:GetHandler():SetStatus(STATUS_ACTIVATED,true)
	if targ then targ(te,tp,eg,ep,ev,re,r,rp,1) end
end
function s.mimica_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local te=c:GetActivateEffect()
	--local ote,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(te:GetCode(),true)
	local oper=te:GetOperation()
	if oper then oper(e,tp,eg,ep,ev,re,r,rp) end
end
function s.mimica_endop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE and c:IsRelateToEffect(e) then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsType(TYPE_CONTINUOUS) then
			Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		elseif not (c:IsType(TYPE_EQUIP) and c:GetEquipTarget()) then
			Duel.SendtoGrave(c,REASON_RULE)
		end
	end
	e:Reset()
end
function s.mimicb_cd(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AssumeProperty(ASSUME_TYPE,c:GetOriginalType())
	local te=c:GetActivateEffect()
	return te:IsActivatable(tp)
end
function s.mimicb_op(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(4001,9)) then return end
	local c=e:GetHandler()
	Duel.ChangePosition(c,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
end