--リミットレギュレーションの予想
--Banlist Predictions
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp)
	local codes={ac}
	s.announce_filter={ac,OPCODE_ISCODE,OPCODE_NOT}
	while (#codes<5 and Duel.SelectYesNo(tp,aux.Stringid(1040,2))) do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
		table.merge(s.announce_filter,{ac,OPCODE_ISCODE,OPCODE_NOT,OPCODE_AND})
		table.insert(codes,ac)
	end
	e:SetOperation(s.operation(codes))
end
function s.operation(codes)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(Card.IsCode,tp,0x7f,0x7f,nil,table.unpack(codes))
		if #g>0 then
			Duel.ConfirmCards(tp,g)
			Duel.Recover(tp,#g,REASON_EFFECT)
			--forbidden
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_FORBIDDEN)
			e1:SetTargetRange(0x7f,0x7f)
			e1:SetTarget(s.bantg(codes))
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.bantg(codes)
	return function(e,c)
		return c:IsCode(table.unpack(codes))
	end
end
table.merge=table.merge or function(t1,t2)
	for i=1,#t2 do
		table.insert(t1,t2[i])
	end
end