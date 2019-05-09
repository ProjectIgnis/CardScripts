--リプロドクス
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2)
	--change property
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,lg,bool)
	--true bool is race and false bool is attribute
	if bool==true then
		return lg:IsContains(c) and c:IsFaceup() and c:GetRace()~=RACE_ALL
	elseif bool==false then
		return lg:IsContains(c) and c:IsFaceup() and c:GetAttribute()~=0x7f
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,true)
			or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,false)
	end
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,true)
	and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,false) then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,true) then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	elseif Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,false) then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	e:SetLabel(op)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if not c:IsRelateToEffect(e) then return end
	local eff=0
	local val=0
	if e:GetLabel()==0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,true) then
		eff=EFFECT_CHANGE_RACE
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
		local share=0
		if #lg>1 then
			for tc in aux.Next(lg) do
				if lg:IsExists(function(c,tc) return c:GetRace()&tc:GetRace()>0 end,#lg-1,tc,tc) then
					if tc:GetRace()&share==0 then share=share+(share~tc:GetRace()) end
				end
			end
		end
		val=Duel.AnnounceRace(tp,1,~share)
	elseif e:GetLabel()~=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,false) then
		eff=EFFECT_CHANGE_ATTRIBUTE
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
		local share=0
		if #lg>1 then
			for tc in aux.Next(lg) do
				if lg:IsExists(function(c,tc) return c:GetAttribute()&tc:GetAttribute()>0 end,#lg-1,tc,tc) then
					if tc:GetAttribute()&share==0 then share=share+(share~tc:GetAttribute()) end
				end
			end
		end
		val=Duel.AnnounceAttribute(tp,1,~share)
	else return
	end
	for tc in aux.Next(lg) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(eff)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
