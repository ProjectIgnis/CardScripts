--ダーク・マター (VG)
--Dark Matter (VG)
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 2 "Dark Matter Tokens" when a Dark Synchro Monster is destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.tkspcon)
	e1:SetTarget(s.tksptg)
	e1:SetOperation(s.tkspop)
	c:RegisterEffect(e1)
end
s.listed_series={0x601} --Dark Synchro
s.listed_names={511000042} --Dark Matter Token
function s.darksyndesfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x601) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function s.tkspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.darksyndesfilter,1,nil)
end
function s.tksptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511000042,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.tkspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.IsPlayerCanSpecialSummonMonster(tp,511000042,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK) then
		local g=Group.CreateGroup()
		for i=1,2 do
			local token=Duel.CreateToken(tp,511000042)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1)
			token:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
			g:AddCard(token)
		end
		Duel.SpecialSummonComplete()
		g:KeepAlive()
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabel(Duel.GetTurnCount()+1)
		e3:SetLabelObject(g)
		e3:SetCondition(s.descon)
		e3:SetOperation(s.desop)
		e3:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local dg=g:Filter(Card.HasFlagEffect,nil,id)
	if #dg>0 then
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		g:DeleteGroup()
		return false
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local dg=g:Filter(Card.HasFlagEffect,nil,id)
	Duel.Destroy(dg,REASON_EFFECT)
end