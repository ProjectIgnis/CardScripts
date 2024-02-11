--いろはもみじ
--Maple Maiden
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Change Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.atttg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)
	--Make the opponent send 1 card to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local rc=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	Duel.SetTargetParam(rc)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local rc=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetValue(rc)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.group(seq,tp)
	local g=Group.CreateGroup()
	local function optadd(loc,seq,player)
		if not player then player=tp end
		local c=Duel.GetFieldCard(player,loc,seq)
		if c then g:AddCard(c) end
	end
	if seq+1<=4 then optadd(LOCATION_MZONE,seq+1) end
	if seq-1>=0 then optadd(LOCATION_MZONE,seq-1) end
	if seq<5 then
		optadd(LOCATION_SZONE,seq)
		if seq==1 then
			optadd(LOCATION_MZONE,5)
			optadd(LOCATION_MZONE,6,1-tp)
		end
		if seq==3 then
			optadd(LOCATION_MZONE,6)
			optadd(LOCATION_MZONE,5,1-tp)
		end
	elseif seq==5 then
		optadd(LOCATION_MZONE,1)
		optadd(LOCATION_MZONE,3,1-tp)
	elseif seq==6 then
		optadd(LOCATION_MZONE,3)
		optadd(LOCATION_MZONE,1,1-tp)
	end
	return g
end
function s.gyfilter(c,tp)
	return #(s.group(c:GetSequence(),1-tp))>0
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MMZONE) and s.gyfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,0,LOCATION_MMZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.gyfilter,tp,0,LOCATION_MMZONE,1,1,nil,tp)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local g=s.group(tc:GetSequence(),1-tp)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.HintSelection(sg,true)
			Duel.SendtoGrave(sg,REASON_RULE,PLAYER_NONE,1-tp)
		end
	end
end